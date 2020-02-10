# Pull all hosts
def get_hosts(report)
  hosts = ManagedHosts.all(report_id: report.id, order: [:ip])
  hosts
end
