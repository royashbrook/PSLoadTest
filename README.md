# PSLoadTest
A primitive load test script for powershell

# notes
1. only works in powershell that supports thread-jobs
2. currently has hard coded success format values and key names and such
3. small server is loaded that will show data sent, no responses are provided though
4. very basic metrics

# todo
1. change harness to allow easier config for what is tested
2. decouple client gen from test logic so clients can spin up based on need and test can be passed in optionally
3. improve threading and scaling up/down. likely switch to runspaces as that is what i typically use for this, but i thought i'd just try raw spin ups of threadjobs. =)
