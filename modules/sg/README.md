# Security Groups module
It's a support module for the rest of the tf app. Only purpose is to contain sg for lb/ec2/endpoints in a separate place. Lacks scaleability.


Instead of piling sg in the root `main.tf` I prefer to pile them up in a separate module if I have no time to write a proper module that does everyting inside of itself. Having everything there allows me to extract it from there and I do not rely on any of this rules later on.
