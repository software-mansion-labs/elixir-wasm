# This file based on elixir-lang Integer module.
#
# Copyright 2012-2022 Elixir Contributors
# https://github.com/elixir-lang/elixir/commits/v1.14.3/lib/elixir/lib/integer.ex
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0
#

defmodule Integer do
  @compile {:autoload, false}
  @moduledoc """
  This module provides functions for working with integers.
  This is not a full implementation of the Elixir Integer module.
  """

  import Bitwise

  defguard is_odd(integer) when is_integer(integer) and (integer &&& 1) == 1

  defguard is_even(integer) when is_integer(integer) and (integer &&& 1) == 0

  def floor_div(dividend, divisor) do
    if dividend * divisor < 0 and rem(dividend, divisor) != 0 do
      div(dividend, divisor) - 1
    else
      div(dividend, divisor)
    end
  end

  def gcd(integer1, integer2) when is_integer(integer1) and is_integer(integer2) do
    gcd_positive(abs(integer1), abs(integer2))
  end

  defp gcd_positive(0, integer2), do: integer2
  defp gcd_positive(integer1, 0), do: integer1
  defp gcd_positive(integer1, integer2), do: gcd_positive(integer2, rem(integer1, integer2))

  def mod(dividend, divisor) do
    remainder = rem(dividend, divisor)

    if remainder * divisor < 0 do
      remainder + divisor
    else
      remainder
    end
  end

  def to_charlist(integer, base \\ 10) do
    :erlang.integer_to_list(integer, base)
  end

  def to_string(integer, base \\ 10) do
    :erlang.integer_to_binary(integer, base)
  end
end
