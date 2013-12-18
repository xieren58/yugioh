# not for ets

defrecord PlayerState,id: 0,name: "",avatar: 0,gender: 0,hp: 0,win: 0,lose: 0,cards: [],socket: nil,in_room_id: 0

# ets record

defrecord PlayerOnline,id: 0,player_pid: nil

defrecord RoomInfo,id: 0,status: nil,name: "",type: 0,owner_pid: nil,members: nil


defmodule RecordHelper do
  require Lager
  alias Yugioh.Proto
  alias Yugioh.Player

  
  def encode_player_brief_info(player_state) do
    <<
    player_state.id::size(32),
    Proto.pack_string(player_state.name)::binary,
    player_state.avatar::size(8)
    >>
  end

  def encode_room_info(room_info) do
    status = case room_info.status do
      :wait ->
        1
      :battle ->
        2
    end

    members_list = Dict.to_list(room_info.members)
    members_data_list = Enum.map members_list,fn({seat,player_pid}) ->
      owner_pid = room_info.owner_pid
      is_owner = case player_pid do
        ^owner_pid ->
          1
        _other ->
          0
      end
      player_state = Player.player_state(player_pid)      
      brief_info = encode_player_brief_info(player_state)
      <<seat::size(8),brief_info::binary,is_owner::size(8)>>
    end

    members_data_binary = iolist_to_binary(members_data_list)

    <<
    room_info.id::size(32),
    status::size(16),
    Proto.pack_string(room_info.name)::binary,
    room_info.type::size(16),
    length(members_list)::size(16),
    members_data_binary::binary
    >>

  end
  
end