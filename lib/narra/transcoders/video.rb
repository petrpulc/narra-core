#
# Copyright (C) 2014 CAS / FAMU
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
# Authors: Michal Mocnak <michal@marigan.net>
#

require 'narra/spi'
require 'streamio-ffmpeg'

module Narra
  module Transcoders
    class Video < Narra::SPI::Transcoder

      # Set title and description fields
      @identifier = :video
      @title = 'Video Transcoder'
      @description = 'Video Transcoder based on ffmpeg'

      def self.valid?(item_to_check)
        item_to_check.type.equal?(:video)
      end

      def transcode(progress_from, progress_to)
        begin
          # set start progress
          set_progress(progress_from)
          
          # set transcoding profiles
          @profiles = []
          
          # assigned progress part
          progress_d = progress_to - progress_from
          
          # proxy profiles
          @profiles << transcode_proxy_object('lq', progress_d / 4)
          @profiles << transcode_proxy_object('hq', progress_d / 2)
          # profile for downloadable file
          @profiles << {
            file: Narra::Tools::Settings.storage_temp + '/' + @item._id.to_s + '_video_copy.mp4',
            key: 'video_copy.mp4',
            options: '-q:v 3 -q:a 4',
            progress_part: progress_d / 4,
            name: 'video_copy'
          }

          # start transcode process
          progress_done = 0
          
          @profiles.each do |profile|
            @raw.transcode(profile[:file], profile[:options]) do |progress|
              set_progress(progress_from + progress_done + (progress * profile[:progress_part]).to_f)
            end
            
            url = @item.create_file(profile[:key], File.open(profile[:file])).public_url
            add_meta(generator: :transcoder, name: profile[:name], value: url)
            
            progress_done+= profile[:progress_part]
          end
        rescue => e
          #clean
          clean
          # raise exception
          raise e
        else
          # set end progress
          set_progress(progress_to)
          #clean
          clean
        end
      end

      def clean
        # clean temp transcodes
        FileUtils.rm_f(@profiles.collect {|p| p[:file]})
      end

      def transcode_proxy_object(type, progress_part)
        {
            file: Narra::Tools::Settings.storage_temp + '/' + @item._id.to_s + '_video_proxy_' + type + '.' + Narra::Tools::Settings.video_proxy_extension,
            key: 'video_proxy_' + type + '.' + Narra::Tools::Settings.video_proxy_extension,
            options: {video_bitrate: Narra::Tools::Settings.get('video_proxy_' + type + '_bitrate'), video_bitrate_tolerance: 100, resolution: Narra::Tools::Settings.get('video_proxy_' + type + '_resolution')},
            progress_part: progress_part,
            name: 'video_proxy_' + type
        }
      end
    end
  end
end
