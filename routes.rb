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

  haml :"../plugins/host_tracker/views/hosts_list"
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

  haml :"../plugins/host_tracker/views/hosts_list"
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

# Delete a template finding
get '/host_tracker/:id/hosts/delete/:host_id' do
  id = params[:id]
  @report = get_report(id)
  params[:host_id].split(',').each do |current_id|
    host = ManagedHosts.first(id: current_id)
    return "No Such Finding : #{current_id}" if host.nil?
    # delete the entries
    host.destroy
  end
  redirect to("/host_tracker/#{id}/hosts")
end
