## Objective

I want to build a working sample of azure pipeline templates that demonstrates how a platform engineering team can provide reusable and extensible pipeline templates for multiple workload teams while enforcing best practices.

I specially want to demonstrate scenarios like:

- Platform team defines a "base-template.yml" that has all the best practices and generic reusable steps/stages/jobs that can be used by multiple workload teams. Treat it like a base class in OOP.
- Then platform team define a second level of abstractions like "container-workload base-template.yml" that extends the "base-template.yml" and adds more specific steps/stages/jobs that are common to containerized workloads. Treat it like a derived class in OOP.
- the container base template then should offer extensibility points like deployment strategy (such as Rolling, Canary, Blue-Green etc) that the workload teams can choose from.
- Based on the workloads team's provided choice, it will enforce the correct deployment strategy. 
- Again the idea is the platform team owns the orchestration and provide the extensibility points, while the workload team just provides the parameters to choose from the available options.


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