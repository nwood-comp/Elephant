package com.Gen10.Elephant.Controller;

import com.Gen10.Elephant.dto.Arrival;
import com.Gen10.Elephant.dto.Attendance;
import com.Gen10.Elephant.dto.Departure;
import java.util.List;
import java.util.ArrayList;

import com.Gen10.Elephant.dto.Arrival;
import com.Gen10.Elephant.dto.Departure;
import com.Gen10.Elephant.dto.TimeSlot;
import com.Gen10.Elephant.dto.User;
import com.Gen10.Elephant.service.ServiceLayer;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/users")
public class UserController {
    
    @Autowired
    ServiceLayer service;

    @GetMapping("/times/{id}")
    public ResponseEntity<List<TimeSlot>> getTimes(@PathVariable int id, @RequestHeader("email") String email, @RequestHeader("password") String password) {
        User dbUser = service.checkUser(email, password);
        if(dbUser != null){
            return new ResponseEntity<List<TimeSlot>>(service.getOpenTimeSlotsByLocationId(id), HttpStatus.OK);
        }
        return new ResponseEntity<List<TimeSlot>>(new ArrayList<TimeSlot>(), HttpStatus.UNAUTHORIZED);
    }

    //checks username(email) and password against system, returns user stored in database if correct, null if incorrect
    @PostMapping("/login")
    @CrossOrigin(origins= "http://localhost:8000")
    public ResponseEntity<User> login(@RequestHeader("email") String email, @RequestHeader("password") String password) {
        User user = new User(email, password);
        User dbUser = service.checkLogin(user);
        if (dbUser != null) {
            return new ResponseEntity<User>(dbUser, HttpStatus.OK);
        }
        return new ResponseEntity<User>(user, HttpStatus.UNAUTHORIZED);
    }

    //edts a user, restricted to password only
    @PostMapping("/editUser")
    public ResponseEntity<User> editUser(@RequestBody User user, @RequestHeader("email") String email, @RequestHeader("password") String password) {
        User dbUser = service.checkUser(email, password);
        User editUser = service.editUserPassword(user);
        if(dbUser != null){
            return new ResponseEntity<User>(editUser, HttpStatus.OK);
        }
        return new ResponseEntity<User>(new User(), HttpStatus.UNAUTHORIZED);
    }

    // Round 2
    @PostMapping("/coming/{id}")
    public ResponseEntity<Attendance> markAttendance(@RequestBody Attendance attendance, @RequestHeader("email") String email, @RequestHeader("password") String password) {
        User dbUser = service.checkUser(email, password);
        if(dbUser != null){
            return new ResponseEntity<Attendance>(service.markAttendance(attendance), HttpStatus.OK);
        }
        return new ResponseEntity<Attendance>(new Attendance(), HttpStatus.UNAUTHORIZED);
    }

    @PostMapping("/arrival/{id}")
    public ResponseEntity<Arrival> reserveArrival(@RequestBody User user, @PathVariable int id, @RequestHeader("email") String email, @RequestHeader("password") String password) {
        User dbUser = service.checkUser(email, password);
        if(dbUser != null){
            return new ResponseEntity<Arrival>(service.reserveArrivalByTimeSlotId(user, id), HttpStatus.OK);
        }
        return new ResponseEntity<Arrival>(new Arrival(), HttpStatus.UNAUTHORIZED);
    }
    
    @PostMapping("/departure/{id}")
    public ResponseEntity<Departure> reserveDeparture(@RequestBody User user, @PathVariable int id, @RequestHeader("email") String email, @RequestHeader("password") String password) {
        User dbUser = service.checkUser(email, password);
        if(dbUser != null){
            return new ResponseEntity<Departure>(service.reserveDepartureByTimeSlotId(user, id), HttpStatus.OK);
        }
        return new ResponseEntity<Departure>(new Departure(), HttpStatus.UNAUTHORIZED);
    }   
}