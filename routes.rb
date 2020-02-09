require 'sinatra'
require './plugins/host_tracker/classes.rb'

  # Now the magic happens
  # Hosts List Menu
get '/report/:id/hosts' do

  @report = true # Honestly not sure what this is happening
  id = params[:id] # Get the ID of the report

  # Query for the first report matching the report_name (or ID?)
  @report = get_report(id) # Get the report


  @plugin_side_menu = get_plugin_list('user') # TODO: Look into how this works

  return 'No Such Report' if @report.nil? # # TODO: Handle this a little more gracefully. Maybe an alert?

  # Hey go get those hosts please
  @hosts = get_hosts(@report)

  haml :"../plugins/host_tracker/views/hosts_list"
end

# Create a new hosts in the report
get '/host_tracker/:id/hosts/new' do
  # Query for the first report matching the report_name
  @report = get_report(params[:id])
  return 'No Such Report' if @report.nil?

  @hosts = get_hosts(@report)

  haml :create_host
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

  @host = Hosts.new(data)
  @host.save

  # for a parameter_pollution on report_id
  redirect to("/report/#{id}/hosts")
end
end
