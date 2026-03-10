#!/usr/bin/python
import os
import pathlib
import platform
import shutil
import sys

from invoke import task

def _project_name():
    return "helloworld"

def _pty():
    if platform.system() == "Windows":
        return False

    return True

def _aws_region():
    return "eu-west-1"

def _activate():
    if platform.system() == "Windows":
        return "call .venv/Scripts/activate.bat"
    return "source .venv/bin/activate"

@task
def test(ctx, stage):
    with ctx.prefix(_activate()):
        os.environ["AWS_DEFAULT_REGION"] = _aws_region()
        os.environ["TABLE_NAME"] = f"{_project_name()}-{stage}"
        ctx.run("python -m pytest")

@task
def lint(ctx):
    """Lint code"""
    ctx.run("echo Running format && uv run ruff format ./src", pty=_pty())
    ctx.run("echo Running lint && uv run ruff check ./src --fix", pty=_pty())

    ctx.run("echo Running mypy && uv run mypy", pty=_pty())

@task
def clean(ctx):
    """Clean"""

    paths = (
        ".testsrun_cache",
        ".pytest_cache",
        ".mypy_cache",
        ".coverage",
        "coverage.xml",
        "junit-report.xml",
        "lambda_function_payload",
        "lambda_function_payload.tar",
        "lambda_function_payload.zip",
    )

    for path in paths:
        path = os.path.join(os.getcwd(), path)
        if os.path.exists(path):
            print(f"Deleting {path}")
            if os.path.isdir(path):
                shutil.rmtree(path, ignore_errors=True)
            else:
                os.remove(path)

@task(pre=[clean])
def build(ctx):
    """Build"""

    build_dir = "lambda_function_payload"
    version_info = sys.version_info
    version = f"python{version_info.major}.{version_info.minor}"

    ctx.run(f"uv venv {build_dir}", pty=_pty())

    if platform.system() == "Windows":
        activate_venv = rf"{build_dir}\Scripts\activate"
        path_to_deps_and_source = f"{build_dir}/Lib/site-packages"
    else:
        activate_venv = f"source {build_dir}/bin/activate"
        path_to_deps_and_source = f"{build_dir}/lib/{version}/site-packages"

    ctx.run(rf"{activate_venv} && uv sync --locked --no-dev --active", pty=_pty())

    # add / remove ["boto3", "botocore"] to remove / keep these packages
    patterns_to_delete = ["**/test*", "**/*.dist-info"]
    for pattern in patterns_to_delete:
        for path in pathlib.Path(path_to_deps_and_source).glob(pattern):
            if path.is_dir():
                shutil.rmtree(path.absolute())

    deps_and_source_paths = [
        os.path.join(path_to_deps_and_source, path) for path in os.listdir(path_to_deps_and_source)
    ]
    deps_and_source_paths.append("src")

    ctx.run(f"python3 -m zipfile -c {build_dir}.zip {' '.join(deps_and_source_paths)}", pty=_pty())


@task
def outdated(ctx):
    """List outdated dependencies"""

    ctx.run("uv tree --outdated", pty=_pty())


@task
def bootstrap(ctx):
    """Bootstrap project"""

    ctx.run("uv sync --locked", pty=_pty())
