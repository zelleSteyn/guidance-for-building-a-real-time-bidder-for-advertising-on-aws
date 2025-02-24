package server

import (
	"bidder/code/metrics"
	"time"

	"github.com/rs/zerolog/log"
)

// ActionLogger provides structured logging and metrics for actions
type ActionLogger struct {
	action     string
	startTime  time.Time
	attributes map[string]interface{}
}

// NewActionLogger creates a new ActionLogger instance
func NewActionLogger(action string) *ActionLogger {
	return &ActionLogger{
		action:     action,
		startTime:  time.Now(),
		attributes: make(map[string]interface{}),
	}
}

// WithAttribute adds an attribute to be logged
func (al *ActionLogger) WithAttribute(key string, value interface{}) *ActionLogger {
	al.attributes[key] = value
	return al
}

// Complete logs the completion of the action and records metrics
func (al *ActionLogger) Complete(err error) {
	duration := time.Since(al.startTime)
	
	// Record metrics
	metrics.ActionDuration.Observe(duration.Seconds())
	if err != nil {
		metrics.ActionCount.WithLabelValues("error").Inc()
	} else {
		metrics.ActionCount.WithLabelValues("success").Inc()
	}

	// Prepare log event
	event := log.Info()
	if err != nil {
		event = log.Error().Err(err)
	}

	// Add all attributes
	for k, v := range al.attributes {
		event = event.Interface(k, v)
	}

	// Add standard fields
	event.Str("action", al.action).
		Float64("duration_seconds", duration.Seconds()).
		Msg("Action completed")
}