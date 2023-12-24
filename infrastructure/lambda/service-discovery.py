import os

import boto3

client_ec2 = boto3.client('ec2')
client_route53 = boto3.client('route53')

# Manages creation and deletion of multivalue A records for an ECS service to load-balance via DNS.
# Necessary because AWS Cloud Map only handles DNS-based service discovery with private IPs.
# Doesn't handle cases with more than 300 records.

# This is NOT suitable for production systems yet - it needs to ensure that tasks are put into DNS only
# when they're passing their health checks.

# Expected env config:
# HOSTED_ZONE_ID: ID of hosted zone to put our records in
# ROOT_DOMAIN: Root domain name of target hosted zone. Don't feel like looking this up automatically.
# TARGET_SUBDOMAIN: Subdomain to create records under.

def get_eni_ip(event):
  try:
    eni_attachment = next(
      attachment
      for attachment
      in event['detail']['attachments']
      if attachment['type'] == 'eni' and attachment['status'] != 'PRECREATED'
    )
  except StopIteration:
    print("No non-precreated ENI attached to this task. Nothing to do.")
    return False

  try:
    eni_id = next(
      detail
      for detail
      in eni_attachment['details']
      if detail['name'] == 'networkInterfaceId'
    )['value']
  except StopIteration:
    print(event)
    raise RuntimeError("No network interface ID listed for this ENI somehow.")

  try:
    enis = client_ec2.describe_network_interfaces(NetworkInterfaceIds=[eni_id])['NetworkInterfaces']

    if len(enis) == 0:
      raise RuntimeError("No ENIs matching returned ID found")

    return enis[0]['Association']['PublicIp']
  except botocore.exceptions.ClientError:
    print("Error looking up network interfaces. Responsible event:")
    print(event)
    raise


def update_record_set(task_arn, ip, action):
  record_sets = client_route53.change_resource_record_sets(
    HostedZoneId=os.environ['HOSTED_ZONE_ID'],
    ChangeBatch={
      'Changes': [
        {
          'Action': action,
          'ResourceRecordSet': {
            'Name': f"{os.environ['TARGET_SUBDOMAIN']}.{os.environ['ROOT_DOMAIN']}",
            'Type': 'A',
            'MultiValueAnswer': True,
            'TTL': 60,
            'ResourceRecords': [{ 'Value': ip }],
            'SetIdentifier': task_arn,
          },
        },
      ],
    },
  )

# Event shape: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_cwe_events.html#ecs_task_events
def lambda_handler(event, context):
  eni_ip = get_eni_ip(event)
  if eni_ip is False:
    print("No ENI on this task, nothing to do.")
    return

  task_arn = event['detail']['taskArn']

  if event['detail']['desiredStatus'] == "RUNNING":
    update_record_set(task_arn, eni_ip, 'UPSERT')
  elif event['detail']['desiredStatus'] == "STOPPED":
    update_record_set(task_arn, eni_ip, 'DELETE')
