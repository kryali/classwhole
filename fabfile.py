from fabric.api import run
from fabric.context_managers import cd
  
def deploy():
  with cd("~/classwhole"):
    run("./deploy.sh")
