package com.electronics.Chato.model;

import lombok.*;

//make changes

// import java.nio.file.FileStore;

/*
 * comment out the @Getter, @Setter, @AllArgsConstructor, and @NoArgsConstructor
 * and then 1) write two constructors one without arguments and another with three arguments
 * 2) for the three variables in the ChatMessage class generate setters
 * 3) for the three variables generate getters
 * The work is complete only of the code will run after the changes have been made.
 */


@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class ChatMessage {
    private String content;
    private String sender;
    private MessageType type;


    public enum MessageType{
        CHAT, LEAVE, JOIN
    }
}
 // Constructor without arguments
    public ChatMessage() {
    }

    // Constructor with three arguments
    public ChatMessage(String content, String sender, MessageType type) {
        this.content = content;
        this.sender = sender;
        this.type = type;
    }

    // Setters for the three variables
    public void setContent(String content) {
        this.content = content;
    }

    public void setSender(String sender) {
        this.sender = sender;
    }

    public void setType(MessageType type) {
        this.type = type;
    }

    // Getters for the three variables
    public String getContent() {
        return content;
    }

    public String getSender() {
        return sender;
    }

    public MessageType getType() {
        return type;
    }
}