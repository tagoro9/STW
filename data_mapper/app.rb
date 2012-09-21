#!/usr/bin/env ruby
require 'rubygems'
require 'sinatra'
require 'haml'
require 'data_mapper'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/agenda.db")

#Definir el modelo
class Contact
   include DataMapper::Resource

   property :id, Serial
   property :firstname, String
   property :lastname, String
   property :email, String
end

DataMapper.auto_upgrade!

#Mostrar lista de contactos
get '/contacts' do
   haml :list, :locals => { :cs => Contact.all}
end

#Formulario para crear un nuevo contacto
get '/contacts/new' do
   haml :form, :locals => {
      :c => Contact.new,
      :action => '/contacts/create'
   }
end

#Crear un nuevo contacto
post '/contacts/create' do
   c = Contact.new
   c.attributes = params
   c.save
   redirect "/contacts/#{c.id}"
end

#Formulario para editar un contacto
get '/contacts/:id/edit' do |id|
   c = Contact.get(id)
   haml :form, :locals => {
      :c => c,
      :action => "/contacts/#{c.id}/update"
   }
end

#Editar un contacto
post '/contacts/:id/update' do |id|
   c = Contact.get(id)
   puts "Fallo al actualizar #{c}" unless c.update(
      :firstname => params[:firstname],
      :lastname => params[:lastname],
      :email => params[:email]
   )
   redirect "/contacts/#{id}"
end

#Borrar un contacto
post '/contacts/:id/destroy' do |id|
   c = Contact.get(id)
   c.destroy
   redirect '/contacts'
end

#Ver un contacto
get '/contacts/:id' do |id|
   c = Contact.get(id)
   haml :show, :locals => {:c => c}
end

__END__

@@ layout
%html
  %head
    %title Agenda
  %body
    = yield
    %a(href="/contacts") Contact List

@@form
%h1 Create a new contact
%form(action="#{action}" method="POST")
  %label(for="firstname") First Name
  %input(type="text" name="firstname" value="#{c.firstname}")
  %br

  %label(for="lastname") Last Name
  %input(type="text" name="lastname" value="#{c.lastname}")
  %br

  %label(for="email") Email
  %input(type="text" name="email" value="#{c.email}")
  %br

  %input(type="submit")
  %input(type="reset")
  %br

- unless c.id == 0
  %form(action="/contacts/#{c.id}/destroy" method="POST")
    %input(type="submit" value="Destroy")
  
@@show
%table
  %tr
    %td First Name
    %td= c.firstname
  %tr
    %td Last Name
    %td= c.lastname
  %tr
    %td Email
    %td= c.email
%a(href="/contacts/#{c.id}/edit") Edit Contact

@@list
%h1 Contacts
%a(href="/contacts/new") New Contact
%table
  - cs.each do|c|
    %tr
      %td= c.firstname
      %td= c.lastname
      %td= c.email
      %td
        %a(href="/contacts/#{c.id}") Show
      %td
        %a(href="/contacts/#{c.id}/edit") Edit
