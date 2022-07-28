/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.randomlogic.perftest.product.dashboard.model;

import java.io.Serializable;

/**
 *
 * @author Paul G. Allen <pgallen@gmail.com>
 */
public class UpdateData implements Serializable
{
    private static final long serialVersionUID = 1L;
    
    private Double retail_price;
    private Double discounted_price;
    private Boolean availability;

    public UpdateData()
    {

    }

    public UpdateData (Double retail_price,
                       Double discounted_price,
                       Boolean availability
                      )
    {
        this.retail_price = retail_price;
        this.discounted_price = discounted_price;
        this.availability = availability;
    }

    public Double getRetail_price()
    {
        return retail_price;
    }

    public void setRetail_price (Double retail_price)
    {
        this.retail_price = retail_price;
    }

    public Double getDiscounted_price()
    {
        return discounted_price;
    }

    public void setDiscounted_price (Double discounted_price)
    {
        this.discounted_price = discounted_price;
    }

    public Boolean getAvailability()
    {
        return availability;
    }

    public void setAvailability (Boolean availability)
    {
        this.availability = availability;
    }
}
