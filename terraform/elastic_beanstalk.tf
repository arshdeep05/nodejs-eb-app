resource "aws_elastic_beanstalk_application" "app" {
  name = "my-nodejs-eb-app"
}


resource "aws_elastic_beanstalk_environment" "app_env" {
  name                = "my-nodejs-env"
  application         = aws_elastic_beanstalk_application.app.name
  solution_stack_name = "64bit Amazon Linux 2023 v6.4.2 running Node.js 18"
  depends_on          = [aws_iam_instance_profile.eb_instance_profile, aws_iam_service_linked_role.autoscaling, aws_iam_service_linked_role.elasticbeanstalk]
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "SingleInstance"
  }


  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.eb_instance_profile.name
  }


}

