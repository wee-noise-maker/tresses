#!/usr/bin/python2.5
#
# Copyright 2012 Emilie Gillet.
#
# Author: Emilie Gillet (emilie.o.gillet@gmail.com)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
# 
# See http://creativecommons.org/licenses/MIT/ for more information.
#
# -----------------------------------------------------------------------------
#
# Master resources file.

header = """--
--  SPDX-License-Identifier: MIT
--
--  Based on Braids from Mutable Instruments:
--  Copyright 2012 Emilie Gillet.
--
--  This file is generated from a script
"""

namespace = 'braids'
target = '../src'
types = ['uint8_t', 'uint16_t']
includes = """
"""

import characters
import lookup_tables
# import samples
import waveforms
import waveshapers

create_specialized_manager = True

resources = [
  # ('dummy', 'string', 'STR', 'char', str, False),
  (lookup_tables.lookup_tables,
   'lookup_table', 'LUT', 'U16', int, False),
  (lookup_tables.lookup_tables_signed,
   'lookup_table_signed', 'LUT', 'S16', int, False),
  (lookup_tables.lookup_tables_32,
   'lookup_table_hr', 'LUT', 'U32', int, False),
  (waveforms.waveforms,
   'waveform', 'WAV', 'S16', int, True),
  (waveshapers.waveshapers,
   'waveshaper', 'WS', 'S16', int, True),
  # (waveforms.wavetable_data,
  #  'wt', 'WT', 'uint8_t', int, False),
  # (characters.characters,
  #  'char', 'CHR', 'uint16_t', int, False),
]