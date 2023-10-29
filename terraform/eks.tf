
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 19.0"
  cluster_name    = var.cluster_name
  cluster_version = "1.27"
  subnet_ids         = module.vpc.private_subnets

  vpc_id = module.vpc.vpc_id
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access = true
  create_kms_key = false

  
  iam_role_additional_policies = {
    EKSClusterAutoScalerPolicy      = aws_iam_policy.cluster_autoscaler_policy_for_eks.arn
    EKSNodegroupClusterIssuerPolicy = aws_iam_policy.eks_nodegroup_cluster_issuer_policy.arn
    EKSNodegroupExternalDNSPolicy   = aws_iam_policy.eks_nodegroup_exteral_dns_policy.arn
  }

  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = ["t2.micro"]
    

    iam_role_additional_policies = {
      EKSClusterAutoScalerPolicy      = aws_iam_policy.cluster_autoscaler_policy_for_eks.arn
      EKSNodegroupClusterIssuerPolicy = aws_iam_policy.eks_nodegroup_cluster_issuer_policy.arn
      EKSNodegroupExternalDNSPolicy   = aws_iam_policy.eks_nodegroup_exteral_dns_policy.arn
    }
  }

  eks_managed_node_groups = {
    python-app-ng = {
      min_size     = 1
      max_size     = 2
      desired_size = 1

      instance_types = ["t2.micro"]
      capacity_type  = "SPOT"


      update_config = {
        max_unavailable_percentage = 33 # or set `max_unavailable`
      }
    }
  }


  cluster_addons = {
  coredns = {
    most_recent = true
  }
  kube-proxy = {
    most_recent = true
  }
  vpc-cni = {
    most_recent = true
  }
}


}