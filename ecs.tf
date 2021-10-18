resource "aws_ecs_cluster" "jb-cluster" {
  name               = var.cluster_name
  capacity_providers = [aws_ecs_capacity_provider.jb_cp.name]
}

resource "aws_iam_service_linked_role" "ecs" {
  aws_service_name = "ecs.amazonaws.com"
}

resource "aws_ecs_capacity_provider" "jb_cp" {
  name = "jb-capacity-provider"
  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.jb_asg.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      status          = "ENABLED"
      target_capacity = 85
    }
  }
  depends_on = [aws_iam_service_linked_role.ecs]
}

resource "aws_ecs_task_definition" "youtrack_task" {
  family                = "youtrack"
  container_definitions    = jsonencode(  [
    {
      name : "youtrack-task",
      image : "jetbrains/youtrack:2021.3.29124",
      essential : true,
      mountPoints: [
        {
          "containerPath": "/opt/youtrack/backups",
          "sourceVolume": "youtrack_storage",
          "readOnly": false
        }
      ],
      logConfiguration: {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": aws_cloudwatch_log_group.logs-youtrack.name,
          "awslogs-region": "us-east-2",
          "awslogs-stream-prefix": "logs-youtrack"
        }
      },
      portMappings : [
        {
          containerPort : 8080,
          hostPort : 8080
        }
      ],
      memory : 1536,
      cpu : 512
    }
  ]
  )
  volume {
    name      = "youtrack_storage"
    efs_volume_configuration {
      file_system_id = module.efs.efs_file_system_id
    }
  }
  network_mode          = "bridge"
}

resource "aws_cloudwatch_log_group" "logs-youtrack" {
  name = "logs-youtrack"
}

resource "aws_ecs_service" "youtrack_service" {
  name            = "youtrack-service"
  cluster         = aws_ecs_cluster.jb-cluster.id
  task_definition = aws_ecs_task_definition.youtrack_task.arn
  desired_count   = 1
  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.youtrack_lb_target_group.arn
    container_name   = "youtrack-task"
    container_port   = 8080
  }
  lifecycle {
    ignore_changes = [desired_count]
  }
  launch_type = "EC2"
  depends_on  = [aws_lb_listener.web-listener]
}