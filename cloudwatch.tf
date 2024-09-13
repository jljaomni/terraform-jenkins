resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/jenkins"
  retention_in_days = 7

  tags = {
    Name = "ecs-jenkins-logs"
  }
}

resource "aws_cloudwatch_dashboard" "ecs_dashboard" {
  dashboard_name = "ecs-container-dashboard"
  
  dashboard_body = jsonencode({
    widgets = [
      # Jenkins CPU Utilization
      {
        "type"       : "metric",
        "x"          : 0,
        "y"          : 0,
        "width"      : 6,
        "height"     : 6,
        "properties" : {
          "metrics" : [
            [ "AWS/ECS", "CPUUtilization", "ClusterName", "${aws_ecs_cluster.ecs_cluster.name}", "ServiceName", "${aws_ecs_service.jenkins_sonarqube_service.name}", "TaskDefinitionFamily", "${aws_ecs_task_definition.jenkins_sonarqube_task.family}", "ContainerName", "jenkins" ]
          ],
          "view"        : "timeSeries",
          "stacked"     : false,
          "region"      : "us-east-1",
          "stat"        : "Average",
          "period"      : 60,
          "title"       : "Jenkins CPU Utilization"
        }
      },
      # SonarQube CPU Utilization
      {
        "type"       : "metric",
        "x"          : 6,
        "y"          : 0,
        "width"      : 6,
        "height"     : 6,
        "properties" : {
          "metrics" : [
            [ "AWS/ECS", "CPUUtilization", "ClusterName", "${aws_ecs_cluster.ecs_cluster.name}", "ServiceName", "${aws_ecs_service.jenkins_sonarqube_service.name}", "TaskDefinitionFamily", "${aws_ecs_task_definition.jenkins_sonarqube_task.family}", "ContainerName", "sonarqube" ]
          ],
          "view"        : "timeSeries",
          "stacked"     : false,
          "region"      : "us-east-1",
          "stat"        : "Average",
          "period"      : 60,
          "title"       : "SonarQube CPU Utilization"
        }
      },
      # Jenkins Memory Utilization
      {
        "type"       : "metric",
        "x"          : 0,
        "y"          : 6,
        "width"      : 6,
        "height"     : 6,
        "properties" : {
          "metrics" : [
            [ "AWS/ECS", "MemoryUtilization", "ClusterName", "${aws_ecs_cluster.ecs_cluster.name}", "ServiceName", "${aws_ecs_service.jenkins_sonarqube_service.name}", "TaskDefinitionFamily", "${aws_ecs_task_definition.jenkins_sonarqube_task.family}", "ContainerName", "jenkins" ]
          ],
          "view"        : "timeSeries",
          "stacked"     : false,
          "region"      : "us-east-1",
          "stat"        : "Average",
          "period"      : 60,
          "title"       : "Jenkins Memory Utilization"
        }
      },
      # SonarQube Memory Utilization
      {
        "type"       : "metric",
        "x"          : 6,
        "y"          : 6,
        "width"      : 6,
        "height"     : 6,
        "properties" : {
          "metrics" : [
            [ "AWS/ECS", "MemoryUtilization", "ClusterName", "${aws_ecs_cluster.ecs_cluster.name}", "ServiceName", "${aws_ecs_service.jenkins_sonarqube_service.name}", "TaskDefinitionFamily", "${aws_ecs_task_definition.jenkins_sonarqube_task.family}", "ContainerName", "sonarqube" ]
          ],
          "view"        : "timeSeries",
          "stacked"     : false,
          "region"      : "us-east-1",
          "stat"        : "Average",
          "period"      : 60,
          "title"       : "SonarQube Memory Utilization"
        }
      }
    ]
  })
}

