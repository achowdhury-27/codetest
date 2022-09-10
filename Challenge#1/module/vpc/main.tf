    #vpc
	resource "aws_vpc" "name" {
	  cidr_block = var.vpc_cidr
	  tags = {
	    Name = "terraform"
		}
	}
	
	#Subnets : public
	resource "aws_subnet" "public" {
	  count = 2
	  vpc_id = aws_vpc.name.id
	  cidr_block = "172.31.1.0/24"
	  availability_zone = element(var.azs,count.index)
	  tags = {
		Name = "terraform-subnet-1"
		}
	}
	#Subnets : public
	resource "aws_subnet" "public1" {
	  count = 2
	  vpc_id = aws_vpc.name.id
	  cidr_block = "172.31.2.0/24"
	  availability_zone = element(var.azs,count.index)
	  tags = {
		Name = "terraform-subnet-2"
		}
	}
	#Subnet: Private
	resource "aws_subnet" "terraform-private-subnet-1" {
	  count = 2
	  vpc_id = aws_vpc.name.id
	  cidr_block = "172.31.3.0/24"
	  availability_zone = element(var.azs,count.index)
	  tags = {
	    Name = "terraform-private-subnet-1"
		}
	}
	#Subnet: Private
	resource "aws_subnet" "terraform-private-subnet-2" {
	  count = 2
	  vpc_id = aws_vpc.name.id
	  cidr_block = "172.31.4.0/24"
	  availability_zone = element(var.azs,count.index)
	  tags = {
	    Name = "terraform-private-subnet-2"
		}
	}
	resource "aws_eip" "nateip" {
	  vpc = true
	}
	 
	#Natgateway
	resource "aws_nat_gateway" "terraform-ng" {
	  
	  allocation_id = aws_eip.nateip.id
	  subnet_id = aws_subnet.public.id
	  tags = { 
	    Name = "terraform-ng"
	  }
	}
	# Route-table for natgateway
	resource "aws_route_table" "terraform-RT" {
	  vpc_id = aws_vpc.name.id
	  route {
	    cidr_block = "0.0.0.0/0"
		gateway_id = aws_nat_gateway.terraform-ng.id
		}
	    tags = {
		  Name = "terraform-RT"
		  }
	}
	resource "aws_route_table_association" "n" {
	  subnet_id = aws_subnet.terraform-private-subnet-1.id
	  route_table_id = aws_route_table.terraform-RT.id
	  }
	
	
	#Internet Gateway
	resource "aws_internet_gateway" "name" {
	  vpc_id = aws_vpc.name.id
	  tags = {
	    Name = "terraform-ig"
		}
	}
	#Route table: attach Internet Gateway
	resource "aws_route_table" "name" {
	  vpc_id = aws_vpc.name.id
	  route {
	    cidr_block = "0.0.0.0/0"
		gateway_id = aws_internet_gateway.name.id
		}
	  tags = {
	    Name = "terraform-route-table"
	  }
    }
    # Route table association with public subnets
    resource "aws_route_table_association" "a" {
      subnet_id	= aws_subnet.public.id
	  route_table_id = aws_route_table.name.id
	}
	resource "aws_route_table_association" "b" {
      subnet_id	= aws_subnet.public1.id
	  route_table_id = aws_route_table.name.id
	}