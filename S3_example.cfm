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
    .US_EAST_1;

// services.s3.S3Client: provide the region and explicit credentials
S3Service = createObject("java","software.amazon.awssdk.services.s3.S3Client")
    .builder()
    .region(awsRegion)
    .credentialsProvider(awsCredentialsProvider)
    .build();

// services.s3.model.ListBucketsRequest
S3ListBucketsRequestService = createObject("java","software.amazon.awssdk.services.s3.model.ListBucketsRequest")
    .builder()
    .build();

// returns an array of S3 bucket ojects
S3BucketObjArray = S3Service
    .listBuckets(S3ListBucketsRequestService)
    .buckets();

// loop over each S3 bucket objects and return its name
for (bucketObj in S3BucketObjArray) {
    writeOutput(bucketObj.name() & '<br>');
}

// Service clients extend the AutoClosable interface, but as a best practice
// - especially with short-lived code such as AWS Lambda functions - you should explicitly call the close() method.
S3Service.close();

// future code note: when you go to create a new bucket or object, use waiters.
// Some requests take time to process, such as creating a new Amazon S3 bucket.
// To ensure the resource is ready before your code continues to run, use a Waiter.
</cfscript>