package com.hackerrank.eshopping.product.dashboard.model;

import java.io.Serializable;

public class Status implements Serializable
{
    private static final long serialVersionUID = 1L;
    
    private String status = "OK";
    
    public Status()
    {
        
    }
    
    public String getStatus()
    {
        return this.status;
    }
    
    public void setStatus (String status)
    {
        this.status = status;
    }
}
