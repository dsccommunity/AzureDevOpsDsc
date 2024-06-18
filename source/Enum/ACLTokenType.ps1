enum AzdoAclTokens
{
    # Project-Level Tokens
    #TeamProject = "vstfs:///Classification/TeamProject/{project-id}"
    TeamProject = 1

    # Repository-Level Tokens
    #Repository = "repoV2/{project-id}/{repository-id}"
    Repository = 2

    # Branch-Level Tokens
    #Branch = "repoV2/{project-id}/{repository-id}/refs/heads/{branch-name}"
    Branch = 3

    # Build Pipeline Tokens
    #BuildPipeline = "build/{project-id}/{pipeline-id}"
    BuildPipeline = 4

    # Release Pipeline Tokens
    #ReleasePipeline = "release/{project-id}/{pipeline-id}"
    ReleasePipeline = 5

    # Agent Pool Tokens
    #AgentPool = "vstfs:///AgentPool/{pool-id}"
    AgentPool = 6

    # Service Connection Tokens
    #ServiceConnection = "vstfs:///ServiceEndpoint/{service-connection-id}"
    ServiceConnection = 7

    # Work Item Tokens
    #WorkItem = "vstfs:///WorkItemTracking/WorkItem/{work-item-id}"
    WorkItem = 8

    # Area Path Tokens
    #AreaPath = "vstfs:///Classification/Node/{node-id}"
    AreaPath = 9

    # Iteration Path Tokens
    #IterationPath = "vstfs:///Classification/Node/{node-id}"
    IterationPath = 10

    # Variable Group Tokens
    #VariableGroup = "vstfs:///DistributedTask/VariableGroup/{variable-group-id}"
    VariableGroup = 11

    # Environment Tokens
    #Environment = "vstfs:///DistributedTask/Environment/{environment-id}"
    Environment = 12

    # Library Tokens
    #Library = "vstfs:///Library/{library-id}"
    Library = 13

    # Test Plan Tokens
    #TestPlan = "vstfs:///TestManagement/TestPlan/{test-plan-id}"
    TestPlan = 14

    # Test Suite Tokens
    #TestSuite = "vstfs:///TestManagement/TestSuite/{test-suite-id}"
    TestSuite = 15

    # Test Case Tokens
    #TestCase = "vstfs:///TestManagement/TestCase/{test-case-id}"
    TestCase = 16

    # Artifact Tokens
    #Artifact = "vstfs:///Artifact/{artifact-id}"
    Artifact = 17

}
