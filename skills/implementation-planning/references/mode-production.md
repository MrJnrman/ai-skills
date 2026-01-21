# Mode: Production

**This plan targets production deployment.** Apply full engineering rigor.

## Production-Grade Requirements

Every production plan must address:

### Reliability & Failure Handling
- All failure modes identified and handled
- Graceful degradation under partial failures
- Timeout and retry strategies defined
- Circuit breaker patterns where appropriate
- Data consistency guarantees explicit

### Security & Privacy
- Authentication and authorization model defined
- Input validation at all boundaries
- Secrets management approach specified
- Data classification and handling rules
- Audit logging for sensitive operations
- OWASP Top 10 considerations addressed

### Observability
- Logging strategy with appropriate levels
- Metrics and KPIs defined
- Alerting thresholds specified
- Distributed tracing integration (if applicable)
- Health check endpoints

### Operability
- Deployment procedure documented
- Rollback procedure tested and documented
- Database migration strategy (if applicable)
- Feature flag strategy (if applicable)
- Runbook for common failure scenarios

### Performance
- Load expectations quantified
- Performance requirements specified (latency, throughput)
- Scaling strategy defined
- Resource limits and quotas

### Testing
- Unit test coverage expectations
- Integration test strategy
- End-to-end test scenarios
- Performance/load test plan
- Chaos/failure injection testing (if critical path)

## Production Must-Fix Criteria

Flag as **MUST-FIX** if any of the following are missing or inadequate:

1. **No rollback plan** — Production changes without revert capability
2. **Undefined failure behavior** — Silent failures, data corruption risks
3. **Missing auth model** — Unclear who can do what
4. **No observability** — Can't tell if it's working or why it failed
5. **Unbounded operations** — Missing pagination, timeouts, or resource limits
6. **Breaking changes without migration** — Backward compatibility ignored
7. **Missing data validation** — Trusting external input
8. **Unclear blast radius** — Scope of impact not defined

## Production-Specific Questions

- What's the blast radius if this fails?
- How do on-call engineers diagnose issues?
- What's the recovery time objective (RTO)?
- What data could be lost and what's the recovery point objective (RPO)?
- How is this monitored? What triggers an alert?
- What's the load testing strategy before rollout?

## Critique Tone

Be thorough and uncompromising. Production systems affect real users. A gap in production planning is a future incident. Better to catch it now than at 3 AM.
