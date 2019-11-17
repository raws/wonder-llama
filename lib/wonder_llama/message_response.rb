module WonderLlama
  class MessageResponse < Response
    def id
      self['id']
    end
  end
end
