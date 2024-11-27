package com.email.messages;

public class PutMsg {
    private final String name;
    private final String email;

    public PutMsg(String name, String email) {
        this.name = name;
        this.email = email;
    }

    public String getName() {
        return name;
    }

    public String getEmail() {
        return email;
    }
}
