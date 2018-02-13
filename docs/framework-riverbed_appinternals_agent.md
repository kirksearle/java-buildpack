# Riverbed Appinternals Agent Framework
The Riverbed Appinternals Agent Framework causes an application to be bound with a Riverbed Appinternals service instance.

<table>
  <tr>
    <td><strong>Detection Criterion</strong></td><td>Existence of a single bound Riverbed Appinternals service.
      <ul>
        <li>Existence of a Riverbed Appinternals service is defined by the <a href="http://docs.cloudfoundry.org/devguide/deploy-apps/environment-variable.html#VCAP-SERVICES"><code>VCAP_SERVICES</code></a> payload containing a service who's name, label or tag has case insensative <code>appinternals</code> as a substring.</li>
      </ul>
    </td>
  </tr>
  <tr>
    <td><strong>Tags</strong></td>
    <td><tt>riverbed-appinternals-agent=&lt;version&gt;</tt></td>
  </tr>
</table>
Tags are printed to standard output by the buildpack detect script

## User-Provided Service
When binding Riverbed Appinternals Agent service using a user-provided service, it must have <code>appinternals</code> as substring. The credential payload can contain following entries: 

| Name | Description
| ---- | -----------
| `dsa_port` | (Optional)The Data Sampling Agent(DSA) port to connect to.
| `rvbd_agent_port` | (Optional) The riverbed agent port to connect to.
| `rvbd_moniker` | (Optional) The moniker name of the application.


### Example Creating Riverbed Appinternals User-Provided Service Payload

``` 
cf cups spring-music-appinternals -p '{"dsa_port":"9999","rvbd_moniker":"my_app"}'
cf bind-service spring-music spring-music-appinternals
```

## Configuration
For general information on configuring the buildpack, including how to specify configuration values through environment variables, refer to [Configuration and Extension][].

The framework can be configured by modifying the [`config/riverbed_appinternals_agent.yml`][] file in the buildpack fork.  The framework uses the [`Repository` utility support][repositories] and so it supports the [version syntax][] defined there.

| Name | Description
| ---- | -----------
| `repository_root` | The URL of the Riverbed Appinternals repository index ([details][repositories]).
| `version` | The version of Riverbed Appinternals to use.

[Configuration and Extension]: ../README.md#configuration-and-extension
[repositories]: extending-repositories.md
[version syntax]: extending-repositories.md#version-syntax-and-ordering
