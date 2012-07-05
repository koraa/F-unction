#
# File:   gen-index.coffee
# Author: Karolin Varner
# Date:   7/1/2012
#
# This file contains an API to generate the json index for PinkText.
#  
##########################################################
#
# This file is part of PinkText.
#
# PinkText is free software: you can redistribute it and/or modify
# it under the terms of the Lesser GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# PinkText is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# Lesser GNU General Public License for more details.
#
# You should have received a copy of the Lesser GNU General Public License
# along with PinkText.  If not, see <http://www.gnu.org/licenses/>.
#

gen_index = (dir, index = path.join dir, "index") ->
    