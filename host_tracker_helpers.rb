# Pull all hosts
def get_hosts(report)
  hosts = ManagedHosts.all(report_id: report.id, order: [:ip])
  hosts
end

def get_host(host, report)
  host = ManagedHosts.first(id: host, report_id: report)
  host
end
