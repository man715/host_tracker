require 'sinatra'
require './plugins/host_tracker/classes.rb'
require './plugins/host_tracker/host_tracker_helpers.rb'

  # Now the magic happens
  # Hosts List Menu
  # We are handling the host list page in two ways.
  # This is because of the way Serpico handles plugins. It sends the report id as a url variable instead of being in the url
get '/host_tracker/hosts' do
  # Check for valid session
  redirect to("/") unless valid_session?
  id = params[:report_id]
  @report = get_report(id)

  @plugin_side_menu = get_plugin_list('user') # TODO: Look into how this works

  #return 'No Such Report' if @report.nil? # # TODO: Handle this a little more gracefully. Maybe an alert?

  # Hey go get those hosts please
  @hosts = get_hosts(@report)

  haml :"../plugins/host_tracker/views/list_hosts"
end
  #Hosts List Menu 2
get '/host_tracker/:id/hosts' do
  # Check for valid session
  redirect to("/") unless valid_session?
  id = params[:id]
  @report = get_report(id)

  @plugin_side_menu = get_plugin_list('user') # TODO: Look into how this works

  #return 'No Such Report' if @report.nil? # # TODO: Handle this a little more gracefully. Maybe an alert?

  # Hey go get those hosts please
  @hosts = get_hosts(@report)

  haml :"../plugins/host_tracker/views/list_hosts"
end

# Create a new hosts in the report
get '/host_tracker/:id/hosts/new' do
  # Query for the first report matching the report_name
  id = params[:id]
  @report = get_report(id)
  return 'No Such Report' if @report.nil?

  @hosts = get_hosts(@report)

  haml :"../plugins/host_tracker/views/create_host"
end

# Create the host in the DB
post '/host_tracker/:id/hosts/new' do
  error = mm_verify(request.POST)
  return error if error.size > 1
  data = url_escape_hash(request.POST)

  id = params[:id]
  @report = get_report(id)
  return 'No Such Report' if @report.nil?

    data['report_id'] = id

  @host = ManagedHosts.new(data)
  @host.save

  # for a parameter_pollution on report_id
  redirect to("/host_tracker/#{id}/hosts")
end

# Delete a template host
get '/host_tracker/:id/hosts/delete/:host_id' do
  id = params[:id]
  @report = get_report(id)
  params[:host_id].split(',').each do |current_id|
    host = ManagedHosts.first(id: current_id)
    return "No Such host : #{current_id}" if host.nil?
    # delete the entries
    host.destroy
  end
  redirect to("/host_tracker/#{id}/hosts")
end



# Edit the host in a report
get '/host_tracker/:id/hosts/edit/:host_id' do
  id = params[:id]

  # Query for the first report matching the report_name
  @report = get_report(id)
  return 'No Such Report' if @report.nil?

  host_id = params[:host_id]

  # Query for all hosts
  @host = ManagedHosts.first(report_id: id, id: host_id)

  return "No Such Host #{@host.ip}" if @host.nil?

  haml :"../plugins/host_tracker/views/edit_host"
end

# Edit a host in the report
post '/host_tracker/:id/hosts/edit/:host_id' do
  # Check for kosher name in report name
  id = params[:id]

  # Query for the report
  @report = get_report(id)

  return 'No Such Report' if @report.nil?

  host_id = params[:host_id]

  # Query for all hosts
  @host = get_host(host_id, id)

  return 'No Such host' if @host.nil?

  # not sure what is going on here
  error = mm_verify(request.POST)
  return error if error.size > 1
  data = url_escape_hash(request.POST)

  data['ip'] = data['ip'] # what is this all about?

  # Update the host
  unless @host.update(data)
    error = ""
    @host.errors.each do |f|
      error = error + f.to_s() + "<br>"
    end
    return "<p>The following error(s) were found while trying to update : </p>#{error}"
  end

  @host.save

  redirect to("/host_tracker/#{id}/hosts")
end
