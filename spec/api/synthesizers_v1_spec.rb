#
# Copyright (C) 2013 CAS / FAMU
#
# This file is part of Narra Core.
#
# Narra Core is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Narra Core is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Narra Core. If not, see <http://www.gnu.org/licenses/>.
#
# Authors: Michal Mocnak <michal@marigan.net>, Krystof Pesek <krystof.pesek@gmail.com>
#


require 'spec_helper'

describe Narra::API::Modules::SynthesizersV1 do
  context 'not authenticated' do
    describe 'GET /v1/synthesizers' do
      it 'returns synthesizers' do
        get '/v1/synthesizers'

        # check response status
        response.status.should == 401

        # parse response
        data = JSON.parse(response.body)

        # check received data
        data['status'].should == 'ERROR'
        data['message'].should == 'Not Authenticated'
      end
    end
  end

  context 'not authorized' do
    describe 'GET /v1/synthesizers' do
      it 'returns synthesizers' do
        get '/v1/synthesizers' + '?token=' + @unroled_token

        # check response status
        response.status.should == 403

        # parse response
        data = JSON.parse(response.body)

        # check received data
        data['status'].should == 'ERROR'
        data['message'].should == 'Not Authorized'
      end
    end
  end

  context 'authenticated & authorized' do
    describe 'GET /v1/synthesizers' do
      it 'returns synthesizers' do
        # send request
        get '/v1/synthesizers' + '?token=' + @author_token

        # check response status
        response.status.should == 200

        # parse response
        data = JSON.parse(response.body)

        # check received data format
        data.should have_key('status')
        data.should have_key('synthesizers')

        # check received data
        data['status'].should == 'OK'
        data['synthesizers'].count.should == 1
      end
    end
  end
end