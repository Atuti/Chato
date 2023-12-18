package com.electronics.Chato.model;

import lombok.*;

//Kelimeshack

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
