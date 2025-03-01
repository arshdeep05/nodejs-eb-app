# Elastic Beanstalk Managed Updates
resource "aws_iam_role_policy_attachment" "eb_managed_updates" {
  role       = aws_iam_role.eb_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkManagedUpdatesCustomerRolePolicy"
}

# Elastic Beanstalk Enhanced Health Monitoring
resource "aws_iam_role_policy_attachment" "eb_enhanced_health" {
  role       = aws_iam_role.eb_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}

# Amazon ECR Full Access (for Elastic Beanstalk using Docker)
resource "aws_iam_role_policy_attachment" "ecr_full_access" {
  role       = aws_iam_role.eb_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}


resource "aws_iam_role_policy_attachment" "eb_service_role" {
  role       = aws_iam_role.eb_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkService"
}

# Attach Enhanced Health Monitoring Policy
resource "aws_iam_role_policy_attachment" "eb_health_monitoring" {
  role       = aws_iam_role.eb_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}

# Choose the correct Elastic Beanstalk policy based on the application type
resource "aws_iam_role_policy_attachment" "eb_web_tier" {
  count      = var.app_type == "web" ? 1 : 0
  role       = aws_iam_role.eb_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_role_policy_attachment" "eb_worker_tier" {
  count      = var.app_type == "worker" ? 1 : 0
  role       = aws_iam_role.eb_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
}

resource "aws_iam_role_policy_attachment" "eb_multicontainer" {
  count      = var.app_type == "docker" ? 1 : 0
  role       = aws_iam_role.eb_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"
}

# Define variable to control which policy to use
variable "app_type" {
  description = "Type of Elastic Beanstalk application (web, worker, docker)"
  type        = string
  default     = "web"
}

resource "aws_iam_service_linked_role" "autoscaling" {
  count            = var.create_autoscaling_role ? 1 : 0
  aws_service_name = "autoscaling.amazonaws.com"
  description      = "Service-linked role for Auto Scaling"
}

resource "aws_iam_service_linked_role" "elasticbeanstalk" {
  count            = var.create_beanstalk_role ? 1 : 0
  aws_service_name = "elasticbeanstalk.amazonaws.com"
  description      = "Service-linked role for Elastic Beanstalk"
}


# ✅ Variables to control role creation
variable "create_autoscaling_role" {
  default = true
}

variable "create_beanstalk_role" {
  default = true
}

resource "null_resource" "delete_autoscaling_role" {
  depends_on = [aws_elastic_beanstalk_environment.app_env, aws_elastic_beanstalk_application.app]

  provisioner "local-exec" {
    command = "aws iam delete-service-linked-role --role-name AWSServiceRoleForAutoScaling || echo 'Role not found, skipping delete'"
  }
}
# ✅ Delete Elastic Beanstalk Service-Linked Role using AWS CLI after app is removed
resource "null_resource" "delete_elasticbeanstalk_role" {
  depends_on = [aws_elastic_beanstalk_environment.app_env, aws_elastic_beanstalk_application.app]

  provisioner "local-exec" {
    command = "aws iam delete-service-linked-role --role-name AWSServiceRoleForElasticBeanstalk || echo 'Role not found, skipping delete'"
  }
}



resource "aws_security_group" "eb_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Ensures cleanup on destroy
  lifecycle {
    prevent_destroy = false
  }
}
