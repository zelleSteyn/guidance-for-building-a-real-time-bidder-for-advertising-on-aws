package metrics

import (
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
)

var (
	ActionDuration = NewBufferedSummary(promauto.NewSummary(prometheus.SummaryOpts{
		Name:       "action_duration_seconds",
		Help:       "Duration of action execution in seconds",
		Objectives: defaultSummaryPercentiles,
	}))

	ActionCount = promauto.NewCounterVec(
		prometheus.CounterOpts{
			Name: "action_total",
			Help: "Total number of actions executed",
		},
		[]string{"status"},
	)
)

func init() {
	// Initialize action metrics
	ActionCount.WithLabelValues("success")
	ActionCount.WithLabelValues("error")
}

// Start the action metrics buffer
func StartActionMetrics() {
	ActionDuration.StartService()
}

// Close the action metrics buffer
func CloseActionMetrics() {
	ActionDuration.CloseService()
}