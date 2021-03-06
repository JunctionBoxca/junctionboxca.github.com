---
title:      Go(ing) to the Clouds
created_at: 2015-05-02 12:00:00 +00:00
layout:     default
published: true
description: AWS is one of the top cloud providers. Amazon CloudFormation makes it easier to manage an entire environment and Golang is an efficient language to develop that tooling in. Combining the two and you have an efficient tool to manage an environments life-cycle.
keywords: golang, aws, aws-sdk-go 
tags: golang aws
---

Cloud computing has made getting an IT based company off the ground cheaper than it's ever been. However the availability of low-cost compute resources isn't pain-free. As you develop your product inevitably the number of services and their associated roles will increase. Each service and role will have different requirements whether it be CPU, memory or IO. This heterogenous enviornment introduces complexity during the provisioning process which makes reproduction difficult due to co-ordiation overhead. Enter Amazon CloudFormation which is described by amazon as;

<blockquote>
"AWS CloudFormation gives developers and systems administrators an easy way to create and manage a collection of related AWS resources, provisioning and updating them in an orderly and predictable fashion."

</blockquote>
In this article I'll cover the basic life-cycle of an environment as described in the following sections;

\# [Dependencies](#dependencies)
\# [Validating Templates](#validating_templates)
\# [Estimating Operating Costs](#estimating_operating_costs)
\# [Stack Provisioning](#stack_provisioning)
\# [Stack Progress](#stack_progress)
\# [Stack Deletion](#cleanup)
\# [Conclusion](#conclusion)

At its core CloudFormation uses JSON based templates that are typically composed of at least these four basic elements that affect provisioning;

\* Parameters - user controlled variables including descriptions, constraints and default values.
\* Mappings - essentially constants specified in a key-value format.
\* Resources - the composition of AWS services you want provisioned.
\* Outputs - any variables or values you want to present to output upon success.

CloudFormation is to environments as configuration management is to servers. It manages all of the complexity of resource ordering for you (for AWS specific components) reducing the need for polling or subscribing to events.

### Dependencies

Quick List:

- functional Go ~1.4 environment.

- aws IAM credentials stored in ~/.aws/credentials

- aws-sdk-go
- CloudFormation template

For the purposes of this article I'll assume you have a functional Go environment that can compile a basic "Hello world" app. If you don't take a look at the offical [Go download](http://golang.org/doc/install) page. First up we'll want to download the latest aws-sdk-go package using go get as follows;

    <code>go get -d -v github.com/awslabs/aws-sdk-go</code>

If you're not familiar with Go this command simply does a checkout of the library at $GOPATH/src making it available for import in any Go program you develop. Next you'll want to download and unpack the AWS [CloudFormation sample template](http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-sample-templates.html) files for your desired region.

Now lets create a project;

    <code>PROJECT=$GOPATH/src/github.com/nfisher/goaws
    mkdir -p "${PROJECT}"
    cat > "${PROJECT}/main.go" <<EOT
    package main

    import "fmt"

    func main() {
     fmt.Println("Hello world!")
    }
    EOT

    go run $PROJECT/main.go</code>

With all of that you should have a simple application that outputs "Hello World". The easiest and cheapest thing to do with a template is get it's parameters. Next up we'll dig into the Go AWS SDK.

### Validating Templates

The best place to start with the CloudFormation components is familiarising yourself with the [documentation](http://godoc.org/github.com/awslabs/aws-sdk-go/service/cloudformation) or the code in your source path. The examples are somewhat lacking but it makes a reasonable reference for the datatypes and functions available. For this section we're particularly interested in validating one of the CloudFormation templates we downloaded (in theory these should compile without error). The method we're interested in is defined as follows;

    <code>func (c *CloudFormation) ValidateTemplate(input *ValidateTemplateInput) (output *ValidateTemplateOutput, err error)</code>

So from the above we can derive that we need to instantiate a CloudFormation struct and a ValidateTemplateInput. To simplify the program you can paste the template directly into the CfTemplate value but for everyday use you'll probably want to either read the template from disk or specify a S3 bucket. Editing our main.go file we'll end up with something like the following;

    <code>package main

    import (
      "log"
      "github.com/awslabs/aws-sdk-go/aws"
      "github.com/awslabs/aws-sdk-go/aws/awsutil"
      awscf "github.com/awslabs/aws-sdk-go/service/cloudformation"
    )

    const CfTemplate = `
    PASTE TEMPLATE CONTENTS HERE
    `

    func main() {
      config := &aws.Config{Region: "eu-west-1"} // specify your preferred region but note that not all regions are made the same in terms of available AZ's and Instance types.
      svc := awscf.New(config) // this instantiates a CloudFormation struct.

      input := &awscf.ValidateTemplateInput{
          TemplateBody: aws.String(CfTemplate),
        }

      template, err := svc.ValdateTemplate(input)
      if err != nil {
        log.Fatal(err) // print error and exit
      }

      log.Println(awsutil.StringValue(template.Description)) // output the templates description if specified.
    }</code>

This program will parse the template and either output the errors associated with it or print the templates description. Some readers may note the awsutil.StringValue and aws.String functions. These are used to distinguish between the absence of a value (nil pointer) and an empty value ("", 0, etc). You'll recognise this idiom if you've used protobufs or thrift.

### Estimating Operating Costs

Now that we've validated our template lets estimate its cost using the [Simple Monthly Calculator](http://calculator.s3.amazonaws.com/index.html). The SDK provides the following method for this;

    <code>func (c *CloudFormation) EstimateTemplateCost(input *EstimateTemplateCostInput) (output *EstimateTemplateCostOutput, err error)</code>

The output of this function will provide you with a URL to your saved cost estimate. The following code will load the template with all of the default values and save a cost estimate on the AWS simple calculator.

    <code>params := make([]*awscf.Parameter, len(template.Parameters)) //initialise an array to the length of the templates available parameters.

    // set the params to the templates default values
    for i, p := range template.Parameters {
      if p.DefaultValue == nil {
        log.Fatalf("Oh noes %v has no default value!", awsutil.StringValue(p.ParameterKey))
      }
      params[i] = &awscf.Parameter{
        ParameterKey: p.ParameterKey,
        ParameterValue: p.DefaultValue,
      }
    }

    costInput := &awscf.EstimateTemplateCostInput{
        Parameters:   params,
        TemplateBody: aws.String(CfTemplate),
      }

    cost, err := svc.EstimateTemplateCost(costInput)
    if err != nil {
      log.Fatal(err)
    }

    log.Println(awsutil.StringValue(cost.URL))</code>

In the above code you'll notice that I've iterated over each of the Parameters that were extracted during the template validation. In reality you'll want to specify your own values (unless you've made or updated the default values in the template). It maybe possible that a default value is missing in which case the above code will cause the program to print an error and exit. The simplest fix is to create a hash and use a value from the look-up or alternatively provide some kind of interaction with the user to prompt them for values (e.g. web-form or command line prompts).

### Stack Provisioning

This is the bit that everyone came for! Provisioning all the things at the speed of webscale! There's not a whole lot new here just building on what's already been done. The SDK method for provisioning a stack is;

    <code>func (c *CloudFormation) CreateStack(input *CreateStackInput) (output *CreateStackOutput, err error)</code>

As I'm sure you've noted by now the call pattern is consistent across the library. Provide an input and receive an output and possible error. One notable difference is that the required input data has increased. It would be nice if a factory method were provided that uses sane defaults prompting you for the required variables but alas this is beta software.

    <code>stackName := "YourMagicalStack"
    createInput := &awscf.CreateStackInput{
        StackName: aws.String(stackName),
        Capabilities: []*string{
          aws.String("CAPABILITY_IAM"),
        },
        OnFailure:        aws.String("DELETE"),
        Parameters:       params,
        TemplateBody:     aws.String(CfTemplate),
        TimeoutInMinutes: aws.Long(20),
      }

    createOutput, err := svc.CreateStack(input)
    if err != nil {
      log.Fatal(err)
    }

    log.Println(awsutil.StringValue(createOutput)) // StackID</code>

Depending on the size and complexity of your stack you'll want to adjust the timeout and what happens on failure. I've specified deletion on failure as I don't care to diagnose any issues and would rather it just clean-up after itself in the case of a failure. Choose what fits your needs. As an example you might want to keep an environment around while developing a template and then once its solid have it do deletion on failure for pre-production environments. Another element to note is the StackName. You can think of this as a user generated name to reference this particular instantiation of the template. If you want to provision another stack you should provide a new name.

### Stack Progress

As fast as AWS makes it for provisioning environments it's still not instant. In order to get an overview of progress you may want to periodically poll the progress. This is done via the following method;

    <code>func (c *CloudFormation) DescribeStackEvents(input *DescribeStackEventsInput) (output *DescribeStackEventsOutput, err error)</code>

You can retrieve the progress using the StackName as follows;

    <code>descInput := &awscf.DescribeStackEventsInput{
        StackName: aws.String(stackName),
      }
    descOutput, err := svc.DescribeStackEvents(descInput)
    if err != nil {
      log.Fatal(err)
    }

    if len(descOutput.StackEvents) > 0 {
      log.Println(awsutil.StringValue(descOutput.StackEvents[0]))
    }</code>

From my observations the stack events are in descending order by time but for completeness sake you might want to iterate through for failures and/or completion.

### Stack Deletion

Now that you've spun-up more stacks than you know what to do with (and made AWS a tidy profit in the process) you'll probably want to bring your AWS bills back down to a sane level. Enter stack deletion!

    <code>func (c *CloudFormation) DeleteStack(input *DeleteStackInput) (output *DeleteStackOutput, err error)</code>

With a small dusting of code that is probably beginning to look as monotonous to read as it is to type you too can delete a stack near you.

    <code>delInput := &awscf.DeleteStackInput{
        StackName: aws.String(stackName),
      }

    delOutput, err := svc.DeleteStack(delInput)
    if err != nil {
      log.Fatal(err)
    } 

    log.Println(awsutil.StringValue(delOutput))</code>

### Conclusion

There you have it a method to manage the life-cycle of repeatable environment generation on AWS. I've left stack updates as an exercise for the reader (UpdateStack **cough** **cough**). As you can see the building blocks are pretty consistent. The hardest bits are figuring out the required parameters for the Inputs. For next steps I'd highly recommend reviewing the [Best Practises](http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/best-practices.html). In an upcoming article I'll outline how to create a CloudFormation template from scratch.

The following gist includes a more complete example that reads a specified template file from disk; [main.go](https://gist.github.com/nfisher/522c303ef325bd5cf43e)

Special thanks to [Mark Needham](http://www.markhneedham.com/blog/) for his feedback.
