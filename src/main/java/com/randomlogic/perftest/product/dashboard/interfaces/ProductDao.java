/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.randomlogic.perftest.product.dashboard.interfaces;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import com.randomlogic.perftest.product.dashboard.model.ProductModel;

/**
 *
 * @author Paul G. Allen <pgallen@gmail.com>
 */
@Repository
public interface ProductDao extends JpaRepository<ProductModel, Long>
{
    @Query ("SELECT p FROM Product p WHERE category = ?1 ORDER BY availability desc, discounted_price asc, id asc")
    List<ProductModel> findByCategory (String category);

    @Query ("SELECT p FROM Product p WHERE category = ?1 AND availability = ?2 ORDER BY discount_percent desc, discounted_price asc, id asc")
    List<ProductModel> findByCategoryAndAvailability (String category, boolean availability);
    
    @Modifying
    @Query(
            value = "truncate table Product",
            nativeQuery = true
    )
    void truncateTable();
}
