# API plugin - Broker Architecture

The **broker pattern** is an architectural pattern that can be used to structure distributed software systems with decoupled components that interact by remote procedure calls. A broker component is responsible for coordinating communication, such as forwarding requests, as well as transmitting results and exceptions. <br>
Why not insert a broker in middle between Security Copilot and the service?

<div align="center">
  <img src="https://github.com/mariocuomo/Experimenting-With-Security-Copilot/blob/main/img/api_broker.png" width="1000"> </img>
</div>

There are at least 3 good reasons to include a broker:
- **API masking** <br>
This way you are hiding the final endpoint from Security Copilot and you do not have a direct Copilot-Service-Copilot communication.
- **Business Logic** <br>
In the broker you can add additional business logic like audit, another security layer, other operations, etc.
- **Integration** <br>
Since Security Copilot can only do GET and POST, you can integrate other HTTP methods like PATCH, PUT and DELETE

The broker can be implemented in different ways through an Azure Logic App, Azure Function, App Service, etc. <br>
In the [NoAuth example](https://github.com/mariocuomo/Experimenting-With-Security-Copilot/tree/main/skilling%20series/Day%202%20-%20API/NoAuth_API), the Nitrxgen service was used. An interesting example of a broker architecture is given by Nikolay Salnikov in this [blog post](https://www.linkedin.com/pulse/how-i-added-custom-skill-microsoft-copilot-security-nikolay-salnikov-6whce/) using a Flask Application.

This [folder](https://github.com/mariocuomo/Experimenting-With-Security-Copilot/tree/main/skilling%20series/Day%202%20-%20API/Broker_API/LogicApp) contains the same example but with an Azure Logic App. 