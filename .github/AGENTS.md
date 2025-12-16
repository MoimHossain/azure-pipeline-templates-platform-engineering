# What this repository's AI agents should know

This repository showcases how a platform engineering team can write azure pipeline yaml templates that enforces best practices and are reusable for multiple workload teams. 

The platform team provides base templates and helper templates that workload team can exten and override parameters to suit their needs.


## **platform-engineering** folder

in the **platform-engineering** folder - we have all the base templates that are generic and reusable across multiple workload teams.

> IMPORTANT: Think of this folder resides in a separate repository (also a seprate project in azure devops) that is consumed by workload teams via referring these templates in their own azure pipeline yaml files.

For the sake of this example we are keeping them in the same repository. But don't assume or write code that assumes these templates are in the same repository as the workload teams.

Always assume that the platform engineering templates are in:

Project Name: platform-engineering
Repository Name: platform-engineering


## **quadrant** folder

in the **quadrant** folder - we have all the workload team specific templates that extends the base templates in the platform-engineering folder.
Again assume that these templates are in a separate repository (also a separate project in azure devops) that is consumed by the workload team via their own azure pipeline yaml files.

When writing or modifying code in this folder, always assume that the quadrant templates are in:

Project Name: quadrant
Repository Name: quadrant
