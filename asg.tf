resource "aws_appautoscaling_target" "ecs_scaling_target" {
  max_capacity       = 4  # Máximo número de tareas que quieres ejecutar
  min_capacity       = 1  # Número mínimo de tareas que deseas ejecutar
  resource_id        = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.jenkins_sonarqube_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# Escalar basado en el uso de CPU
resource "aws_appautoscaling_policy" "ecs_cpu_scaling_policy" {
  name               = "ecs-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_scaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_scaling_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_scaling_target.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 50.0  # Escala si el uso de CPU promedio es superior al 50%
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    scale_in_cooldown  = 60  # Espera de 60 segundos antes de reducir tareas
    scale_out_cooldown = 60  # Espera de 60 segundos antes de aumentar tareas
  }
}

# Escalar basado en el uso de Memoria
resource "aws_appautoscaling_policy" "ecs_memory_scaling_policy" {
  name               = "ecs-memory-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_scaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_scaling_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_scaling_target.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 60.0  # Escala si el uso de memoria promedio es superior al 60%
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}
