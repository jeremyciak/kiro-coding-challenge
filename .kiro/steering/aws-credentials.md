---
inclusion: always
---

# AWS Credentials Management

## Terminal Sessions

When opening a new terminal or starting a background process that requires AWS access:

1. **Check for AWS credentials** before running AWS CLI or CDK commands
2. **Prompt the user** to set credentials if not already configured:
   ```powershell
   $env:AWS_ACCESS_KEY_ID="your-access-key"
   $env:AWS_SECRET_ACCESS_KEY="your-secret-key"
   $env:AWS_SESSION_TOKEN="your-session-token"  # if using temporary credentials
   $env:AWS_DEFAULT_REGION="us-west-2"
   ```
3. **Verify credentials** are working before proceeding with deployment commands

## Commands Requiring AWS Credentials

- `cdk deploy`
- `cdk bootstrap`
- `cdk synth` (when accessing AWS resources)
- `aws` CLI commands
- Any script that interacts with AWS services

## Best Practices

- Never hardcode credentials in code or configuration files
- Use environment variables for temporary sessions
- Consider using AWS CLI profiles for persistent configuration: `aws configure`
- Remind users that session tokens expire and may need refreshing
