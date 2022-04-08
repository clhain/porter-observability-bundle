# Applab POC Bundle - Volterra Namespace and vk8s Cluster

This project contains a porter-wrapped set of terraform modules that deploy a volterra namespace and vk8s cluster to that namespace.
It's part of a proof of concept deployment and not production ready.

A bundle is intended to be referenced by either a higher level collection of related bundles (e.g. a namespace + a resource in the namespace),
or a full end to end solution bundle.

Porter is used to provide a common interface to the deployable resource regardless of the underlying IaC or other tooling used to deploy it.

## Component vs Bundle vs Solution
The Applab POC repo is arranged with Components, Bundles, and Solutions as the high level object types. The hierarchy is generally:

components => bundles => solutions

The lowest level component porter bundles are expected to contain most of the terraform or other IaC spec used to define a deployable object. These are then referenced in either
'bundle' porter bundles (containing multiple components frequently used together) or end to end 'solutions' porter bundles (containing everything needed for a
complete solution i.e. app deployment).

This is intended to allow SMEs for a low level component to define the deployment bundle once and then have that be referenced elsewhere. Because porter is the wrapper
regardless of the IaC tooling used inside the bundle, users or Applab maintainers can compose higher order bundles without concern for the specific tooling used inside a particular
component bundle.

> :warning: **Porter currently only supports direct dependencies**: In other words, a bundle that references this bundle will not execute this code if it's then referenced in a 
> third, top level bundle. Because of this, these example 'bundle' porter bundles are actually implementing terraform directly instead of just defining the 'component' porter
> bundles as dependencies. Once indirect dependency support is added in porter, the terraform from this project should be removed in favor of using the volterra/namespace and
> volterra/vk8s-cluster components as dependencies.

## Build and Publish
To build the porter image locally:
```
$ porter build
Copying porter runtime ===> 
Copying mixins ===> 
Copying mixin terraform ===> 

Generating Dockerfile =======>

Writing Dockerfile =======>

Starting Invocation Image Build (clhainf5/volterra-ns-vk8s-installer:v0.0.1) =======> 
```

To publish the docker image:
```
$ porter publish
Pushing CNAB invocation image...
The push refers to repository [docker.io/clhainf5/volterra-ns-vk8s-installer]
77457f9b5587: Preparing
...
c0a294e617df: Pushed
1a8ca40ed75b: Pushed
v0.0.1: digest: sha256:9bbca3f72c589170d5dd28f516e9d1b528824517bea84fd97d1fe29ef6898f34 size: 2211

Rewriting CNAB bundle.json...
Starting to copy image clhainf5/volterra-ns-vk8s-installer:v0.0.1...
Completed image clhainf5/volterra-ns-vk8s-installer:v0.0.1 copy
Bundle tag docker.io/clhainf5/volterra-ns-vk8s:v0.0.1 pushed successfully, with digest "sha256:bf1aa042bef439efafaaaf950de9c80a684c1c5f9dd219845ec975476093b710"
```

## Bundle Explain Output

```
Name: volterra-ns-vk8s
Description: A porter bundle which deploys a volterra namespace and virtual k8s cluster.
Version: 0.0.1
Porter Version: v0.38.7

Credentials:
Name                         Description                                                                Required   Applies To
volterra_api_cred_password   The password for the volterra API credential p12 file.                     true       All Actions
volterra_api_creds           The volterra API credential p12 file to use to authenticate to Volterra.   true       All Actions

Parameters:
Name           Description                                                                                        Type     Default                     Required   Applies To
api_p12_file   The path to the Volterra API P12 File.                                                             string   /root/.volterra/creds.p12   false      All Actions
name           The name of the volterra namespace to create.                                                      string                               false      All Actions
name_prefix    The prefix of the volterra namespace to create, which will be prepended to a random ID.            string                               false      All Actions
tfstate        The tfstate file containing the current terraform state.                                           file     <nil>                       true       show,uninstall,upgrade
volt_api_url   The hostname of the volterra tenant to deploy to (https://<tenant>.console.ves.volterra.io/api).   string   <nil>                       true       All Actions

Outputs:
Name             Description                  Type     Applies To
cluster_name     The default cluster_name     string   install,upgrade
namespace_name   The default namespace_name   string   install,upgrade
tfstate                                       string   All Actions

Actions:
Name   Description   Modifies Installation   Stateless
show   show          true                    false

No dependencies defined

```

## Usage

### Authentication
Whether used as a dependency or directly, porter credentials `volterra_api_creds` and `volterra_api_cred_password` must be defined, containing api access credentials.
See terraform and volterra docs for more info.

### Use As A Dependency
The bundle is intended for use either directly or as a dependency to another bundle. The higher level bundle would reference a volterra-ns-vk8s bundle as follows.
See the porter [dependencies doc](https://porter.sh/dependencies/) for more information.

> :warning: **Porter currently only supports direct dependencies**: In other words, a bundle that references this bundle will not execute this code if it's then referenced in a 
> third, top level bundle.

```
name: some-top-level-bundle
version: 0.0.1
description: "A top-level deployable bundle that is not used as a dependency (see warning above)."
registry: clhainf5

dependencies:
  - name: volterra-ns-vk8s
    reference: clhainf5/volterra-ns-vk8s:v0.0.1
    parameters:
      name: my-namespace
      volt_api_url: https://<tenant>.console.ves.io/api
...
```

### Direct Usage
A parameter and credential set should be generated containing the values to use for the variables listed in the bundle explanation. For more info, see
the Porter [Parameter Quick Start](https://porter.sh/quickstart/parameters/) and [Credential Quick Start](https://porter.sh/quickstart/credentials/) for more.

Once defined, install the bundle as follows:

`porter install -c my-credential-set -p my parameter set`