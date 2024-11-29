## START

```
Terraform init
Terraform validate
Terraform plan
Terraform aply
```

##  구성

###  Compute Instances
| Resource | Name | 역할 | 비고 |  
| -- | --| -- | -- | 
| oci_core_instance | app_node | 인스턴스 | 
| tls_private_key | compute_ssh_key | 인스턴스 SSH 키 | algorithm : RSA |

###  Networking
| Resource | Name | 역할 | 비고 |
| -- | --| -- | -- | 
| oci_core_virtual_network | app_vcn | Virtual Cloud Network (VCN)	| 172.0.0.0/16 |
| oci_core_internet_gateway | app_gateway | Internet Gateway | -> route_table |
| oci_core_route_table | app_route_table | Route Table | 0.0.0.0/0 |
| oci_core_security_list | app_security_list | Ingress/egress rules 설정 | |
| oci_core_subnet | app_subnet | 인스턴스 허용 방화벽 | |

### Load Balancer
| Resource | Name | 역할 | 비고 |
| -- | --| -- | -- | 
| oci_load_balancer_load_balancer | app_load_balancer | Load Balancer | flexible |
| oci_load_balancer_backend_set | app_http_backend_set | Backend Set (HTTP)	| 80 |
| oci_load_balancer_backend | app_http_backend | private_ip 연결 | 80 |
| oci_load_balancer_listener | nginx_http_listener | 외부 허용 포트 | 80(TCP) |
| oci_load_balancer_backend_set | app_https_backend_set	| Backend Set (HTTPS) | 443 |
| oci_load_balancer_backend | app_https_backend | private_ip 연결 | 443 |
| oci_load_balancer_listener | nginx_https_listener | 외부 허용 포트 | 443 (TCP) |

### oracle 방화벽 허용이 안되는 이슈
> #### [unable to open amy port except default 22](https://www.reddit.com/r/oraclecloud/comments/srgfxx/unable_to_open_any_port_except_default_22/)
> 
> 현상 : subnet 수정 후, instance을 reboot 필요함 (~2024.11.29)
> <li>/etc/reuls.v4 수정 적용<br>
> <li>instance 생성 후, reboot 추가<br>
> <li>instance public ip로 cloudflare 연결<br>