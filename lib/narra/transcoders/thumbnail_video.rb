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
    class ThumbnailVideo < Narra::SPI::Transcoder

      # Set title and description fields
      @identifier = :thumbnail_video
      @title = 'Video Thumbnail Transcoder'
      @description = 'Video Thumbnail Transcoder based on ffmpeg'

      def self.valid?(item_to_check)
        item_to_check.type.equal?(:video)
      end

      def transcode(progress_from, progress_to)
        # set start progress
        set_progress(progress_from)

        # calculate seek ratio
        ratio = (@raw.duration / Integer(Narra::Tools::Settings.thumbnail_count)).to_i

        # generate all thumbnails
        (1..Narra::Tools::Settings.thumbnail_count.to_i).each do |count|
          begin
            # seek
            seek = '%05d' % (((count * ratio) == @raw.duration) ? (count * ratio) - 1 : count * ratio)
            # get thumbnail object
            thumbnail = thumbnail_object(seek)
            # generate
            @raw.screenshot(thumbnail[:file], thumbnail[:options], preserve_aspect_ratio: :height, validate: false)
            # copy to storage
            url = @item.create_file(thumbnail[:key], File.open(thumbnail[:file])).public_url
            # create meta
            add_meta(generator: :thumbnail, name: 'thumbnail_' + seek, content: url, marks: [{in: seek.to_f}])
            # delete
            FileUtils.rm_f(thumbnail[:file])
          rescue => e
            # delete
            FileUtils.rm_f(thumbnail[:file])
            # raise exception
            raise e
          end
        end

        # set end progress
        set_progress(progress_to)
      end

      def thumbnail_object(seek)
        {
            file: Narra::Tools::Settings.storage_temp + '/' + @item._id.to_s + '_video_thumbnail_' + seek,
            key: 'thumbnail_' + seek + '.' + Narra::Tools::Settings.thumbnail_extension,
            options: {seek_time: seek.to_i, resolution: Narra::Tools::Settings.thumbnail_resolution}
        }
      end
    end
  end
end