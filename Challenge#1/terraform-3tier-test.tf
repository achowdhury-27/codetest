	provider "aws" {
	  region 	= "us-east-1"
	}
	
	module "vpc" {
    source = "./module/vpc"
	}
	
    resource "aws_instance" "app" {
      ami	= "ami-0aa108435"
	  instance_type = "t3a.micro"
	  availability_zone = "us-east-1a"
	  subnet_id = module.vpc.aws_subnet.terraform-private-subnet-1
	  tags = {
	    Name = "terraform-instance"
	  }
	}
	resource "aws_instance" "app1" {
      ami	= moudle.vpc.var.aws_ami
	  instance_type = "t3a.micro"
	  availability_zone = "us-east-1b"
	  subnet_id = module.vpc.aws_subnet.terraform-private-subnet-2
	  tags = {
	    Name = "terraform-instance"
	  }
	}
	resource "aws_security_group" "app" {
      name        = "app"
      vpc_id      = module.vpc.aws_vpc.name.id

      ingress {
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["172.31.0.0/16"]
      
    }

      egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      
      }

      tags = {
      Name = "app"
      }
    }
    resource "aws_network_interface_sg_attachment" "sg_attachment" {
      security_group_id    = aws_security_group.app.id
      network_interface_id = aws_instance.app.primary_network_interface_id
    }
	resource "aws_network_interface_sg_attachment" "sg_attachment1" {
      security_group_id    = aws_security_group.app.id
      network_interface_id = aws_instance.app1.primary_network_interface_id
    }
	
	resource "aws_lb_target_group_attachment" "Tgroup-at1" {
      target_group_arn = aws_lb_target_group.terraform-TGroup.arn
      target_id        = aws_instance.app.id
      port             = 80
    }
	resource "aws_lb_target_group_attachment" "Tgroup-at2" {
      target_group_arn = aws_lb_target_group.terraform-TGroup.arn
      target_id        = aws_instance.app1.id
      port             = 80
    }
	resource "aws_lb_target_group" "terraform-TGroup" {
	  name     = "terraform-TGroup"
      port     = 80
      protocol = "HTTP"
      vpc_id   = module.vpc.aws_vpc.name.id
    }
	resource "aws_security_group" "lb_sg" {
	  name = "aws_lb.terraform-app-ALB.id.lb_sg"
	  vpc_id = module.vpc.aws_vpc.name.id
      ingress {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      }
      egress {
      from_port   = 0
      to_port     = 0
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
	   }
    }
	
	resource "aws_lb" "terraform-app-ALB" {
	  name               = "terraform-app-ALB"
      internal           = false
      load_balancer_type = "application"
	  
      security_groups    = [aws_security_group.lb_sg.id]
      
	  subnet_mapping {
        subnet_id     = module.vpc.aws_subnet.public.id
        }
	  subnet_mapping {
        subnet_id     = module.vpc.aws_subnet.public1.id
        }
	  tags = {
        Name = "terraform-app-ALB"
        }
	}

	resource "aws_lb_listener" "terraform-listener" {
	  load_balancer_arn = aws_lb.terraform-app-ALB.arn
      port              = "80"
      protocol          = "HTTP"
        default_action {
          type             = "forward"
          target_group_arn = aws_lb_target_group.terraform-TGroup.arn
        }
    }
	
	resource "aws_security_group" "ltemp_sgroup" {
	  
	  vpc_id = module.vpc.aws_vpc.name.id
      ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      }
      egress {
      from_port   = 0
      to_port     = 0
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
	   }
    }
		
	resource "aws_launch_template" "terraform-LTemp" {
      name_prefix   = "terraform-LTemp"
      image_id      = moudle.vpc.var.aws_ami
      instance_type = "t3a.large"
	}
    
    resource "aws_autoscaling_group" "terraform" {
      vpc_zone_identifier = [module.vpc.aws_subnet.terraform-private-subnet-1.id, module.vpc.aws_subnet.terraform-private-subnet-2.id]	
     
      desired_capacity   = 1
      max_size           = 2
      min_size           = 1

      launch_template {
        id  = aws_launch_template.terraform-LTemp.id
        version = "$Latest"
       }
    }
	resource "aws_security_group" "rds" {
	  
	  vpc_id = module.vpc.aws_vpc.name.id
      ingress {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = ["172.31.0.0/16"]
      }
      egress {
      from_port   = 0
      to_port     = 0
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
	   }
    }
	
	resource "aws_db_subnet_group" "postgres-subnet" {
      name       = "postgres-subnet"
      subnet_ids = [module.vpc.aws_subnet.terraform-private-subnet-1.id, module.vpc.aws_subnet.terraform-private-subnet-2.id]

      tags = {
        Name = "postgres-subnet"
      }
    }
	resource "aws_db_instance" "postgres-rds" {
	  
	  identifier             = "postgres-rds"
      instance_class         = "db.t3.large"
      allocated_storage      = 10
	  max_allocated_storage  = 100
	  storage_encrypted     = true
      engine                 = "postgres"
      engine_version         = "12"
	  name                   = "xlrt"
      username               = "prmadmin"
      password               = "1B3ngal1"
	  port                   = 5432
	  multi_az               = true
	  apply_immediately      = true
	 
      vpc_security_group_ids = [aws_security_group.rds.id]
	  maintenance_window     = "Mon:00:00-Mon:03:00"
	  backup_window          = "03:00-06:00"
      backup_retention_period = 7
      db_subnet_group_name    = aws_db_subnet_group.postgres-subnet.id
      
      publicly_accessible     = false
	  deletion_protection     = true
      skip_final_snapshot     = true
	  tags = {
        Environment = "xlrt-rds"
      }
    }
