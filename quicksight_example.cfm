<cfscript>
// AWS SDK for Java 2.x Developer Guide: https://docs.aws.amazon.com/sdk-for-java/latest/developer-guide

// These really should not be stored in code. Do not expose this to any repo, nor share this. Instead, it's better to add a IAM policy for an
// AWS EC2 instance or use an option from the default credential provider chain. When you do this, you can remove the credentialsProvider call.
// https://docs.aws.amazon.com/sdk-for-java/latest/developer-guide/credentials.html
iam_key = "";
iam_secret = "";

// supply static credentials explicitly
// Java API Reference:
// https://sdk.amazonaws.com/java/api/latest/software/amazon/awssdk/auth/credentials/AwsBasicCredentials.html
awsBasicCredentials = createObject("java","software.amazon.awssdk.auth.credentials.AwsBasicCredentials")
    .create(iam_key, iam_secret);
awsCredentialsProvider = createObject("java","software.amazon.awssdk.auth.credentials.StaticCredentialsProvider")
    .create(awsBasicCredentials);

// regions.Region: set the region we want to work in (Ohio)
awsRegion = createObject("java","software.amazon.awssdk.regions.Region")
    .US_EAST_2;

QSClient = createObject("java","software.amazon.awssdk.services.quicksight.QuickSightClient")
    .builder()
    .region(awsRegion)
    .credentialsProvider(awsCredentialsProvider)
    .build();

writeDump(QSClient);

QSClient.close();

</cfscript>