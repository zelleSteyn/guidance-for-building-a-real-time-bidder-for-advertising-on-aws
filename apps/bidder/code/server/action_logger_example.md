# Action Logger Usage Example

The ActionLogger provides a standardized way to log actions and collect metrics. Here's how to use it:

```go
func SomeFunction() error {
    // Create a new action logger
    al := NewActionLogger("process_bid_request")
    
    // Add relevant attributes
    al.WithAttribute("request_id", requestID).
       WithAttribute("client_id", clientID)
    
    // Defer completion logging
    var err error
    defer al.Complete(err)
    
    // Do work...
    err = doSomething()
    return err
}
```

This will:
1. Log the action with all attributes
2. Record the duration in Prometheus
3. Track success/error counts
4. Automatically handle error logging if an error occurs

The logs will be structured and the metrics will be available in Prometheus under:
- `action_duration_seconds` (summary)
- `action_total` (counter with status label)