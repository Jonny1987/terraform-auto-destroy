import subprocess


def terraform_destroy():
    def _run_cmd(command, **kwargs):
        subprocess.run(command, check=True, **kwargs)

    _run_cmd(["cp", "-r", ".", "/tmp/"])
    _run_cmd(["/opt/terraform", "init"], cwd="/tmp/main")
    _run_cmd(["/opt/terraform", "destroy", "-auto-approve", "-var", f"n_proxies=200"], cwd="/tmp/main")


def run(event, context):
    terraform_destroy()
