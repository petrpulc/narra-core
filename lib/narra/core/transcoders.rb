#
# Copyright (C) 2015 CAS / FAMU
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

module Narra
  module Core
    module Transcoders

      # Return all active transcoders
      def Core.transcoders
        # Get all descendants of the Generic generator
        @transcoders ||= Narra::SPI::Transcoder.descendants
      end

      private

      # Return all active transcoders
      def self.transcoders_identifiers
        # Get array of synthesizers identifiers
        @transcoders_identifiers ||= Core.transcoders.collect { |transcoder| transcoder.identifier }
      end
    end
  end
end