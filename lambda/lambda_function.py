import os
import boto3


def lambda_handler(event, context):
  """Updates the desired count for a service"""
  cluster = os.getenv('CLUSTER', 'minecraft')
  service = os.getenv('SERVICE', 'minecraft-server')
  ecs = boto3.client('ecs', region_name=os.getenv('REGION', 'us-east-1'))

  resp = ecs.describe_services(
    cluster=cluster,
    services=[service],
  )
  desired = resp.get('services', [{}])[0].get('desiredCount', 0)

  if desired == 0:
    ecs.update_service(
      cluster=cluster,
      service=service,
      desiredCount=1,
    )
    print(f'Updated desiredCount to 1 (cluster={cluster}, service={service})')
  else:
    print(f'desiredCount already at 1 (cluster={cluster}, service={service})')
