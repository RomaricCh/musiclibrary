#!/usr/bin/python
import os
import platform

from invoke import task


def _project_name():
    return "helloworld"

def _aws_region():
    return "eu-west-1"

def _venv_dir():
    if platform.system() == "Windows":
        return "venv"
    return ".venv"

def _activate():
    if platform.system() == "Windows":
        return "call %s/Scripts/activate.bat" % _venv_dir()
    return "source %s/bin/activate" % _venv_dir()

def _pty():
    if platform.system() == "Windows":
        return False
    return True

@task
def test(ctx, stage):
    with ctx.prefix(_activate()):
        os.environ["AWS_DEFAULT_REGION"] = _aws_region()
        os.environ["TABLE_NAME"] = f"{_project_name()}-{stage}"
        ctx.run(f"PYTHONPATH=src python -m pytest")

@task
def venv(ctx):
    """Create virtualenv"""
    ctx.run("python -m venv %s" % _venv_dir(), pty=_pty())
    with ctx.prefix(_activate()):
        ctx.run("python -m pip install --upgrade pip setuptools wheel invoke wget", pty=_pty())

@task(pre=[venv])
def bootstrap(ctx):
    """Bootstrap"""
    with ctx.prefix(_activate()):
        ctx.run(" python -m pip install -e .", pty=_pty())
        if os.path.exists("dev-requirements.txt"):
            ctx.run(" python -m pip install -r dev-requirements.txt", pty=_pty())
        if os.path.exists("test-requirements.txt"):
            ctx.run(" python -m pip install -r test-requirements.txt", pty=_pty())
