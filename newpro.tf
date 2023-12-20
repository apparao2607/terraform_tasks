terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}




provider "aws" {
  region  = "us-east-1"
  profile = "san"
}

resource "aws_launch_template" "foo" {
  name = "home_template"

  image_id      = "ami-0c7217cdde317cfec"
  instance_type = "t2.micro"
  key_name      = "veeer"

  network_interfaces {
    associate_public_ip_address = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "project"
    }
  }
 
  user_data = base64encode(
    <<-EOF
    #!/bin/bash
    sudo -i
    sudo apt-get update
    sudo apt-get install -y apache2
    echo "<html><body><h1>Hello $INSTANCE_HOSTNAME Welcome to the homepage...!!!</h1></body></html>" | sudo tee /var/www/html/index.html
    sudo service apache2 restart
    EOF
  )
}

################################################################################################################################################################

resource "aws_launch_template" "moo" {
  name = "mobile_template"

  image_id      = "ami-0c7217cdde317cfec"
  instance_type = "t2.micro"
  key_name      = "veeer"

  network_interfaces {
    associate_public_ip_address = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "project"
    }
  }
 
  user_data = base64encode(
    <<-EOF
    #!/bin/bash
    sudo -i
    sudo apt-get update
    sudo apt-get install -y apache2
    sudo systemctl start apache2
    sudo systemctl enable apache2
    mkdir /var/www/html/mobile/
    echo "<html><body><h1>Hello $INSTANCE_HOSTNAME Welcome to the mobile_page ...!!!</h1></body></html>" | sudo tee /var/www/html/mobile/index.html
    sudo service apache2 restart
    EOF
  )
}

##############################################################################################################################################################

resource "aws_launch_template" "loo" {
  name = "laptop_template"

  image_id      = "ami-0c7217cdde317cfec"
  instance_type = "t2.micro"
  key_name      = "veeer"

  network_interfaces {
    associate_public_ip_address = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "project"
    }
  }
 
  user_data = base64encode(
    <<-EOF
    #!/bin/bash
    sudo -i
    sudo apt-get update
    sudo apt-get install -y apache2
    sudo systemctl start apache2
    sudo systemctl enable apache2
    sudo mkdir /var/www/html/laptop/
    echo "<html><body><h1>Hello $INSTANCE_HOSTNAME Welcome to the laptop_page ...!!!</h1></body></html>" | sudo tee /var/www/html/laptop/index.html
    sudo service apache2 restart
    EOF
  )
}



#######  AUTOSCALING  #########################

resource "aws_autoscaling_group" "foo" {
  name                      = "home-asg"
  max_size                  = 3
  min_size                  = 1
  desired_capacity          = 1
  target_group_arns    = [
    aws_lb_target_group.foo.arn 
  ]

  launch_template {
    id      = aws_launch_template.foo.id
    version = "$Latest"
  }
  
  vpc_zone_identifier       = ["subnet-04d85e73ef2fde4f6", "subnet-023bfc126230ce8f4"]
  
  tag {
    key                 = "lorem"
    value               = "ipsum"
    propagate_at_launch = false
  }
}



resource "aws_autoscaling_group" "moo" {
  name                      = "mobile-asg"
  max_size                  = 3
  min_size                  = 1
  desired_capacity          = 1
  target_group_arns    = [
    aws_lb_target_group.moo.arn
  ]

  launch_template {
    id      = aws_launch_template.moo.id
    version = "$Latest"
  }
  
  vpc_zone_identifier       = ["subnet-04d85e73ef2fde4f6", "subnet-023bfc126230ce8f4"]
  
  tag {
    key                 = "lorem"
    value               = "ipsum"
    propagate_at_launch = false
  }
}



resource "aws_autoscaling_group" "loo" {
  name                      = "laptop-asg"
  max_size                  = 3
  min_size                  = 1
  desired_capacity          = 1
  target_group_arns    = [
    aws_lb_target_group.loo.arn
  ]

  launch_template {
    id      = aws_launch_template.loo.id
    version = "$Latest"
  }
  
  vpc_zone_identifier       = ["subnet-04d85e73ef2fde4f6", "subnet-023bfc126230ce8f4"]
  health_check_type         = "EC2"
  health_check_grace_period = 300 
  tag {
    key                 = "lorem"
    value               = "ipsum"
    propagate_at_launch = false
  }
}

###########    Target Group for home  ###########

resource "aws_lb_target_group" "foo" {
  name     = "Home-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id = "vpc-0461fb86f6cae8f4a"
}


###########    Target Group for mobile  ###########

resource "aws_lb_target_group" "moo" {
  name     = "Mobile-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-0461fb86f6cae8f4a"
}



###########    Target Group for laptop  ###########

resource "aws_lb_target_group" "loo" {
  name     = "Laptop-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-0461fb86f6cae8f4a"
}








########### APPLICATION LB #########
resource "aws_lb" "foo" {
  name               = "project-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = ["subnet-04d85e73ef2fde4f6", "subnet-023bfc126230ce8f4"]

    tags = {
    Environment = "production"
  }
}










############# Listner rule ######################




resource "aws_lb_listener" "foo" {
  load_balancer_arn = aws_lb.foo.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.foo.arn
    type             = "forward"
 
    }
  }


resource "aws_lb_listener_rule" "foo" {
  listener_arn = aws_lb_listener.foo.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.foo.arn
  }

  condition {
    path_pattern {
      values = ["/"]
    }
}
}

resource "aws_lb_listener_rule" "moo" {
 listener_arn = aws_lb_listener.foo.arn
  priority     = 101

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.moo.arn
  }

  condition {
    path_pattern {
      values = ["/mobile/"]
    }
  }
}

resource "aws_lb_listener_rule" "loo" {
 listener_arn = aws_lb_listener.foo.arn
  priority     = 102

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.loo.arn
  }

  condition {
    path_pattern {
      values = ["/laptop/"]
    }
  }
}