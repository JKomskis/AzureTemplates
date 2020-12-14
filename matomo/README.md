# Matomo

## Usage

* Fill in the empty configuration values in `deployment/matomo.conf`
* Run `./matomo/deployment/deploy.sh` to deploy the service.
* Add a DNS A record from analytics.jkomskis.com to the IP of the created VM.
* To remove the deployment, run `./matomo/deployment/destroy_deployment.sh`.
